import express from 'express'
import { StatusCodes } from 'http-status-codes'
import { userRoute } from './userRoute'
import { activityRoute } from './activityRoute'
import { dailySummaryRoute } from './dailySummaryRoute'

const Router = express.Router()

Router.get('/status', (req, res) => {
  res.status(StatusCodes.OK).json({ message: 'APIs V1 are ready to use!' })
})

Router.use('/user', userRoute)
Router.use('/activity', activityRoute)
Router.use('/daily-summary', dailySummaryRoute)

export const APIs_V1 = Router