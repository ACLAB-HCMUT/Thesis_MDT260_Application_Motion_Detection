import { MongoClient, ServerApiVersion } from 'mongodb'
import { env } from '~/config/environment'

let databaseInstance = null

//define the mongo client instance
const mongoClientInstance = new MongoClient(env.MONGODB_URI, {
  serverApi: {
    version: ServerApiVersion.v1,
    strict: true,
    deprecationErrors: true
  }
})

// Connect to the database
export const CONNECT_DB = async () => {
  await mongoClientInstance.connect()

  databaseInstance = mongoClientInstance.db(env.DATABASE_NAME)
}

// Disconnect from the database
export const DISCONNECT_DB = async () => {
  await mongoClientInstance.close()
  databaseInstance = null
}

// Get the database instance
export const GET_DB = () => {
  if (!databaseInstance) {
    throw new Error('Database not connected')
  }

  return databaseInstance
}

