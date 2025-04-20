import express from 'express'
import validateToken from '~/middlewares/validateToken'
import { StatusCodes } from 'http-status-codes'
import { activitesController } from '~/controllers/activitiesController'
import updateDailySummaryMiddleware from '~/middlewares/updateDailySummaryMiddleware'

const activityRouter = express.Router()

activityRouter.get('/status', (req, res) => {
  res.status(StatusCodes.OK).json({ message: 'Activity route are ready to use!' })
})
activityRouter.post(
  '/submit',
  validateToken,
  activitesController.submitActivities,
  updateDailySummaryMiddleware
)

export const activityRoute = activityRouter