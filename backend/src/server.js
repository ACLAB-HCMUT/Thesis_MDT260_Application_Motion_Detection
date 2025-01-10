/* eslint-disable no-console */
import express from 'express'
import { CONNECT_DB, DISCONNECT_DB } from '~/config/mongodb'
import exitHook from 'async-exit-hook'
import { env } from '~/config/environment'

//function to start server
const START_SERVER = () => {
  const app = express()

  app.get('/', async (req, res) => {
    res.end('<h1>Hello World!</h1><hr>')
  })

  app.listen(env.APP_PORT, env.APP_HOST, () => {
    // eslint-disable-next-line no-console
    console.log(`Server running at http://${env.APP_HOST}:${env.APP_PORT}/`)
  })

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

