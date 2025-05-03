import express from 'express'
import validateToken from '~/middlewares/validateToken'
import { dailySummariesController } from '~/controllers/dailySummariesController'

const dailySummaryRouter = express.Router()

dailySummaryRouter.get('/:date', validateToken, dailySummariesController.getSingleDailySummary)


export const dailySummaryRoute = dailySummaryRouter