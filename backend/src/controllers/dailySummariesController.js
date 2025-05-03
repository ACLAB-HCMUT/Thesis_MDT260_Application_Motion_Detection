import { USER_MODEL } from '~/models/userModel'
import { StatusCodes } from 'http-status-codes'
import { DAILY_SUMMARY_MODEL } from '~/models/dailySummaryModel'
import ApiError from '~/utils/ApiError'

const getSingleDailySummary = async (req, res, next) => {
  const userId = req.user.id
  const user = await USER_MODEL.findOneById(userId)

  if (!user) {
    return next(new ApiError(StatusCodes.NOT_FOUND, 'User not found'))
  }

  const { date } = req.params
  if (!date) {
    return next(new ApiError(StatusCodes.BAD_REQUEST, 'Date is required'))
  }

  const dailySummary = await DAILY_SUMMARY_MODEL.getSingleDailySummary(userId, date)
  if (!dailySummary) {
    return next(new ApiError(StatusCodes.NOT_FOUND, 'Daily summary not found'))
  }

  return res.status(StatusCodes.OK).json({
    status: 'success',
    message: 'Daily summary retrieved successfully',
    data: {
      dailySummary
    }
  })
}

export const dailySummariesController = {
  getSingleDailySummary
}