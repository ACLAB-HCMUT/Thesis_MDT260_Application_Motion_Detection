import express from 'express'
//import { activityController } from '~/controllers/activityController'
import validateToken from '~/middlewares/validateToken'
import { StatusCodes } from 'http-status-codes'

const activityRouter = express.Router()

activityRouter.get('/status', (req, res) => {
  res.status(StatusCodes.OK).json({ message: 'Activity route are ready to use!' })
})

export const activityRoute = activityRouter