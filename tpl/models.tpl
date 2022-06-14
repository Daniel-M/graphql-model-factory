const {
  Schema,
  mongoose,
} = require('../services/db')

const { BaseSchema } = require('./base')

const _ = require('lodash')

const { 
  generateUuid,
} = require('../utils')

const {{ .Name }}Schema = new Schema({ {{ if .Spec }}{{ range $key, $value := .Spec }}
  {{ $key }}: {{ if .array }}[{{end}}{ {{ if not .ref }}
    type: {{ .type }},{{ else }}
    type: Schema.Types.ObjectId,{{ end }}{{ if .required }}
    required: {{ .required }},{{ end }}{{ if .ref }}
    ref: '{{ .ref }}',{{ end }} {{ if .default }}
    default: {{ .default }}, {{ end }}
  }{{ if .array }}]{{end}},{{ end }}{{ end }}
})

{{ .Name }}Schema.add(BaseSchema)

const {{ .Name }} = mongoose.model('{{ .Name }}', {{ .Name }}Schema)

{{ .Name }}Schema.pre('save', async function(next) {
  if (!this.uuid) {
    this.uuid = await generateUuid({{ .Name }})
  }

  // Create associated stuff when the document is new 
  if (this.isNew) {
  }

  next()
})

{{ .Name }}Schema.post('save', async function(doc) {
  return await doc.populate('organization')
    .populate('createdBy')
    .populate('updatedBy')
    .populate('createdBy.organization')
    .populate('updatedBy.organization'){{ if .Spec }}{{ range $key, $value := .Spec }}{{ if .ref }}
    .populate('{{ $key }}'){{ end }}{{ end }}{{ end }}
})

{{ .Name }}Schema.pre(/^find/, function(next) {
  this.populate('organization')
    .populate('createdBy')
    .populate('updatedBy')
    .populate('createdBy.organization')
    .populate('updatedBy.organization'){{ if .Spec }}{{ range $key, $value := .Spec }}{{ if .ref }}
    .populate('{{ $key }}'){{ end }}{{ end }}{{ end }}
    .sort('-updatedAt')
  next()
})

{{ .Name }}Schema.statics.addOne = async function ({
  {{ .LowerName }},
  user,
}) {

  {{ .LowerName }}.createdBy = user.id
  {{ .LowerName }}.organization = user.organization.id

  return {{ .Name }}.create({{ .LowerName }})
}

{{ .Name }}Schema.statics.findByIdUuid = async function ({id, uuid, organization}) {

  let filterSelector = {}

  if (id) {
    filterSelector = {...filterSelector, _id: id}
  }

  if (uuid) {
    filterSelector = {...filterSelector, uuid}
  }

  if (organization) {
    filterSelector = {...filterSelector, organization: organization.id}
  }

  if (_.isEmpty(filterSelector)){
    throw new Error('Insufficient data to perform lookup')
  }

  return this.findOne(filterSelector)
}

{{ .Name }}Schema.statics.findOneAndUpdateByIdUuid = async function({
  updates, 
  user,
  options: opts
}) {

  let filterSelector = {}
  const { organization } = user || {}

  if (('id' in updates)) {
    const { id } = updates
    filterSelector = { ...filterSelector, _id: id, organization: organization.id }
  }

  if (('uuid' in updates)) {
    filterSelector = { ...filterSelector, uuid: updates.uuid, organization: organization.id }
  }

  if (!filterSelector) {
    throw new Error('Insufficient data to perform updates')
  }

  // We wont update these
  delete updates.id
  delete updates.uuid
  delete updates.organization
  delete updates.createdBy
  delete updates.createdAt
  updates.updatedAt = new Date()
  updates.updatedBy = user.id

  return this.updateOne(filterSelector, updates, {new: true, runValidators: true, ...opts})
}

{{ .Name }}Schema.statics.deleteByIdUuid = async function ({id, uuid, user, options: opts}) {

  if (!id && !uuid || !user) {
    throw new Error('Insufficient data to perform deletion')
  }

  const { organization } = user || {}
  let filterSelector = {organization: organization.id}

  if (id) {
    filterSelector = {...filterSelector, _id: id}
  }

  if (uuid) {
    filterSelector = {...filterSelector, uuid}
  }

  if (!filterSelector) {
    throw new Error('Require _id or uuid to perform updates')
  }

  // We wont update these
  await this.updateOne(filterSelector, {
    updatedAt: new Date(),
    updatedBy: user.id
  }, {new: true, runValidators: true, ...opts})

  return this.delete(filterSelector)
}

module.exports = {
  {{ .Name }},
}
