const { 
  {{ .Name }}: { 
    {{ .Name }},
  },
} = require('../models')

module.exports = {
  Query: {
    {{ .LowerName }}s: async (parent, args, context, info) => {
      if (context.user.level === 0) {
        return await {{ .Name }}.find()
      }

      return await {{ .Name }}.find({
        organization: context.user.organization.id,
      })
    },
    {{ .LowerName }}: async (parent, {id, uuid}, context, info) => {
      if (context.user.level === 0) {
        return await {{ .Name }}.findByIdUuid({id, uuid})
      }      

      return await {{ .Name }}.findByIdUuid({id, uuid, user: context.user})
    },
  },
  Mutation: {
    add{{ .Name }}: async (parent, { {{ .LowerName }} }, context, info ) => {
      try {

        const created{{ .Name }} = await {{ .Name }}.addOne({
          {{ .LowerName }},
          user: context.user,
        })

        return {
          code: 200,
          success: true,
          message: "{{ .Name }} created",
          {{ .LowerName }}: created{{ .Name }},
        }
      } catch (err) {
        console.error(err)
        let code = 500
        if (err.message.match(/(Insufficient data|does not exists|Invalid)/gi)) {
          code = 400
        }

        return {
          code,
          success: false,
          message: err.message,
          error: err,
        }
      }
    },
    update{{ .Name }}: async (parent, { {{ .LowerName }} }, context, info ) => {
      try {

        const {{ .LowerName }}Updated = await {{ .Name }}.findOneAndUpdateByIdUuid({
          updates: {{ .LowerName }},
          user: context.user,
        })

        return {
          code: 200,
          success: true,
          message: "{{ .Name }} updated",
          {{ .LowerName }}: {{ .LowerName }}Updated,
        }
      } catch (err) {
        console.error(err)
        let code = 500
        if (err.message.match(/(Insufficient data|does not exists|Can not update|Invalid)/gi)) {
          code = 400
        }

        return {
          code,
          success: false,
          message: err.message,
          error: err,
        }
      }
    },
    delete{{ .Name }}: async (parent, {id, uuid}, context, info ) => {
      try {

        const deleted = await {{ .Name }}.deleteByIdUuid({id, uuid, user: context.user})

        return {
          code: 200,
          success: true,
          message: "{{ .Name }} deleted",
        }
      } catch (err) {
        console.error(err)
        let code = 500
        if (err.message.match(/(Insufficient data|does not exists|Can not delete|Invalid)/gi)) {
          code = 400
        }

        return {
          code,
          success: false,
          message: err.message,
          error: err,
        }
      }
    },
  } 
}
