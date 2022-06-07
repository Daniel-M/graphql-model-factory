"""
Type {{ .Name }} that defines a {{ .LowerName }}
"""
type {{ .Name }} {
  id: ID!
  uuid: ID!{{ if .Spec }}{{ range $key, $value := .Spec }}{{if not .ref}}
  {{ $key }}: {{ .type }}{{else}}
  {{ $key }}: {{ .ref }}{{end}}{{ if .required }}!{{end}}{{ end }}{{ end }}
  organization: Organization! 
  createdBy: User! 
  updatedBy: User 
  createdAt: String!
  updatedAt: String!
}

"""
Input data to update {{ .LowerName }} 
"""
input {{ .Name }}UpdateInput {
  id: ID
  uuid: ID{{ if .Spec }}{{ range $key, $value := .Spec }}{{ if .modifiable }}
  {{ $key }}: {{ .type }}{{end}}{{ end }}{{ end }}
}

"""
Input data to create {{ .LowerName }} 
"""
input {{ .Name }}Input { {{ if .Spec }}{{ range $key, $value := .Spec }}{{if not .ref}}
  {{ $key }}: {{ .type }}{{else}}
  {{ $key }}: {{ .ref }}{{end}}{{ if .required }}!{{end}}{{ end }}{{ end }}
}


type Mutation {
  """
  Add a new {{ .LowerName }} 
  """
  add{{ .Name }}({{ .LowerName }}: {{ .Name }}Input!): {{ .Name }}Mutation
  """
  Update an existing {{ .LowerName }}
  """
  update{{ .Name }}({{ .LowerName }}: {{ .Name }}UpdateInput!): {{ .Name }}Mutation
  """
  Delete a {{ .LowerName }}
  """
  delete{{ .Name }}(id: ID uuid: ID): MutationResponseType
}

type Query {
  """
  Retrieve the {{ .Name }}s
  """
  {{ .LowerName }}s: [{{ .Name }}]
  """
  Retrieve a {{ .LowerName }} by its id, uuid
  """
  {{ .LowerName }}(id: ID uuid: ID): {{ .Name }}
}


type {{ .Name }}Mutation implements MutationResponse {
  """
  Status code returned by the mutation

  """
  code: Int!
  """
  Did the mutation succeded?

  """
  success: Boolean!
  """
  An informative message explaining the status

  """
  message: String!
  """
  {{ .Name }} associated with the operation performed by the mutation 
  """
  {{ .LowerName }}: {{ .Name }} 
  """
  A message that informs about the current error, if any
  """
  error: String
}
