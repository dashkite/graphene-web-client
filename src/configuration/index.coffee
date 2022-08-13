import configurations from "./configurations"
environment = process.env.mode ? process.env.NODE_ENV ? "development"
console.log "Loading Graphene Web client configuration for #{environment}"
configuration = configurations[ environment ]

export default configuration