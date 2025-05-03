import express from 'express'
import validateToken from '~/middlewares/validateToken'
import { dailySummariesController } from '~/controllers/dailySummariesController'

const dailySummaryRouter = express.Router()

dailySummaryRouter.get('/:date', validateToken, dailySummariesController.getSingleDailySummary)

// GET /daily-summary?startDate=YYYY-MM-DD&endDate=YYYY-MM-DD
dailySummaryRouter.get('/', validateToken, dailySummariesController.getDailySummaryByDateRange)

export const dailySummaryRoute = dailySummaryRouter