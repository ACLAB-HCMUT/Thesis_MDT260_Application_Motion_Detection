import express from 'express'
//import { activityController } from '~/controllers/activityController'
import validateToken from '~/middlewares/validateToken'
import { StatusCodes } from 'http-status-codes'
import { activitesController } from '~/controllers/activitiesController'

const activityRouter = express.Router()

activityRouter.get('/status', (req, res) => {
  res.status(StatusCodes.OK).json({ message: 'Activity route are ready to use!' })
})
activityRouter.post('/submit', validateToken, activitesController.submitActivities)

export const activityRoute = activityRouter