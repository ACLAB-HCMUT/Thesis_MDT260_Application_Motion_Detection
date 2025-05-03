import { USER_MODEL } from '~/models/userModel'
import { StatusCodes } from 'http-status-codes'
import { DAILY_SUMMARY_MODEL } from '~/models/dailySummaryModel'
import { ACTIVITY_MODEL } from '~/models/activityModel'
import ApiError from '~/utils/ApiError'

// Utility function to validate date format
const isValidDateFormat = (date) => {
  const dateRegex = /^\d{4}-\d{2}-\d{2}$/ // YYYY-MM-DD format
  return dateRegex.test(date)
}

const getSingleDailySummary = async (req, res, next) => {
  try {
    const userId = req.user.id
    const user = await USER_MODEL.findOneById(userId)

    if (!user) {
      return next(new ApiError(StatusCodes.NOT_FOUND, 'User not found'))
    }

    const { date } = req.params
    if (!date) {
      return next(new ApiError(StatusCodes.BAD_REQUEST, 'Date is required'))
    }

    //Check if the date is YYYY-MM-DD format
    if (!isValidDateFormat(date)) {
      return next(new ApiError(StatusCodes.BAD_REQUEST, 'Date must be in YYYY-MM-DD format'))
    }

    const dailySummary = await DAILY_SUMMARY_MODEL.getSingleDailySummary(userId, date)
    if (!dailySummary) {
      return next(new ApiError(StatusCodes.NOT_FOUND, 'Daily summary not found'))
    }

    // Calculate the start and end of the day for the date
    const startOfDay = new Date(date)
    startOfDay.setUTCHours(0, 0, 0, 0)
    const endOfDay = new Date(date)
    endOfDay.setUTCHours(23, 59, 59, 999)

    // Fetch activities for the specified date
    const activities = await ACTIVITY_MODEL.getActivitiesByDateRange(userId, startOfDay, endOfDay)

    return res.status(StatusCodes.OK).json({
      status: 'success',
      message: 'Daily summary retrieved successfully',
      data: {
        dailySummary,
        activities
      }
    })
  } catch (error) {
    return next(new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message))
  }
}

const getDailySummaryByDateRange = async (req, res, next) => {
  try {
    const userId = req.user.id

    const { startDate, endDate } = req.query // Extract startDate and endDate from query parameters
    if (!startDate || !endDate) {
      return next(new ApiError(StatusCodes.BAD_REQUEST, 'Start date and end date are required'))
    }

    //Check if the dates are in YYYY-MM-DD format
    if (!isValidDateFormat(startDate) || !isValidDateFormat(endDate)) {
      return next(new ApiError(StatusCodes.BAD_REQUEST, 'Dates must be in YYYY-MM-DD format'))
    }

    const dailySummaries = await DAILY_SUMMARY_MODEL.getDailySummariesByDateRange(userId, startDate, endDate)

    if (!dailySummaries || dailySummaries.length === 0) {
      return res.status(StatusCodes.NOT_FOUND).json({
        status: 'fail',
        message: 'No daily summaries found for the specified date range'
      })
    }

    //Sumarize the daily summaries
    const summary = dailySummaries.reduce(
      (acc, summary) => {
        acc.total_steps += summary.total_steps
        acc.total_calories += summary.total_calories
        acc.total_walking_time += summary.total_walking_time
        acc.total_running_time += summary.total_running_time
        acc.total_stepping_stair_time += summary.total_stepping_stair_time
        acc.total_idle_time += summary.total_idle_time
        return acc
      },
      {
        total_steps: 0,
        total_calories: 0,
        total_walking_time: 0,
        total_running_time: 0,
        total_stepping_stair_time: 0,
        total_idle_time: 0
      }
    )
    res.status(StatusCodes.OK).json({
      status: 'success',
      message: `Daily summaries from ${startDate} to ${endDate} retrieved successfully`,
      data: {
        summary
      }
    })
  } catch (error) {
    return next(new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message))
  }
}

export const dailySummariesController = {
  getSingleDailySummary,
  getDailySummaryByDateRange
}