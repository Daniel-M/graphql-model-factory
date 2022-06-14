"""
Type {{ .Name }} that defines a {{ .LowerName }}
"""
type {{ .Name }} {
  id: ID!
  uuid: ID!
  name: String!
  description: String!{{ if .Spec }}{{ range $key, $value := .Spec }}{{if not .ref}}
  {{ $key }}: {{ if .array }}[{{end}}{{ .type }}{{ if .required }}!{{end}}{{ if .array }}]{{end}}{{else}}
  {{ $key }}: {{ if .array }}[{{end}}{{ .ref }}{{ if .required }}!{{end}}{{ if .array }}]{{end}}{{end}}{{end}}{{end}}
  organization: Organization! 
  createdBy: User! 
  updatedBy: User 
  createdAt: String!
  updatedAt: String
}

"""
Input data to update {{ .LowerName }} 
"""
input {{ .Name }}UpdateInput {
  id: ID
  uuid: ID
  name: String
  description: String{{ if .Spec }}{{ range $key, $value := .Spec }}{{if .modifiable}}{{if not .ref}}
  {{ $key }}: {{ if .array }}[{{end}}{{ .type }}{{else}}
  {{ $key }}: {{ if .array }}[{{end}}{{ .ref }}UpdateInput{{end}}{{ if .array }}]{{end}}{{end}}{{end}}{{end}}
}

"""
Input data to create {{ .LowerName }} 
"""
input {{ .Name }}Input { 
  name: String!
  description: String!{{ if .Spec }}{{ range $key, $value := .Spec }}{{if not .ref}}
  {{ $key }}: {{ if .array }}[{{end}}{{ .type }}{{else}}
  {{ $key }}: {{ if .array }}[{{end}}{{ .ref }}Input{{end}}{{ if .required }}!{{end}}{{ if .array }}]{{end}}{{end}}{{end}}
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
