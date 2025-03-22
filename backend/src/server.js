/* eslint-disable no-console */
import express from 'express'
import { CONNECT_DB, DISCONNECT_DB } from '~/config/mongodb'
import exitHook from 'async-exit-hook'
import { env } from '~/config/environment'
import { APIs_V1 } from '~/routes/v1'
import { errorHandlingMiddleware } from '~/middlewares/errorHandlingMiddleware'

//function to start server
const START_SERVER = () => {
  const app = express()

  //parse request body to json format
  app.use(express.json())

  app.use('/v1', APIs_V1)

  //error handling middleware
  app.use(errorHandlingMiddleware)

  if (env.BUILD_MODE === 'production') {
    app.listen(env.APP_PORT, env.APP_HOST, () => {
      console.log(`Server running at http://${env.APP_HOST}:${env.APP_PORT}/`)
    })
  } else {
    app.listen(env.APP_PORT, env.APP_HOST, () => {
      console.log(`Server running at http://${env.APP_HOST}:${env.APP_PORT}/`)
    })
  }

  exitHook(() => {
    console.log('Server is shutting down...')
    DISCONNECT_DB()
    console.log('Database disconnected')
  })
}

//function to connect to database before starting server
(async () => {
  try {
    console.log('Connecting to database...')
    await CONNECT_DB()
    console.log('Database connected')
    START_SERVER()
  }
  catch (error) {
    // eslint-disable-next-line no-console
    console.error(error)
    process.exit(0)
  }
})()

