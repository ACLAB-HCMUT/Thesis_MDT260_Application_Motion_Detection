import { DAILY_SUMMARY_MODEL } from '~/models/dailySummaryModel.js'
import { ACTIVITY_MODEL } from '~/models/activityModel.js'
import ApiError from '~/utils/ApiError'
import { StatusCodes } from 'http-status-codes'
import calculateCalories from '~/utils/calculateCalories.js'

const updateDailySummaryMiddleware = async (req, res, next) => {
  try {
    const { userId } = req.user //Extract userId from the request object
    const { date } = req.body //Extract date from the request body

    //First, fetch all activities for the user on the specified date
    const startOfDay = new Date(date)
    startOfDay.setHours(0, 0, 0, 0) // Set to start of the day

    const endOfDay = new Date(date)
    endOfDay.setHours(23, 59, 59, 999) // Set to end of the day

    const activities = await ACTIVITY_MODEL.getActivitiesByDateRange(userId, startOfDay, endOfDay)

    //If no activities are found, return a 200 status with an empty array
    if (activities.length === 0) {
      return res.status(StatusCodes.OK).json({ message: 'No activities found for the specified date.', activities: [] })
    }

    //Calculate total calories burned from activities
    const totalCalories = calculateCalories(activities) //Calculate total calories burned from activities

    //Update or create the daily summary for the user
    await DAILY_SUMMARY_MODEL.updateOrCreateDailySummary(userId, date, activities)


  } catch (error) {
    next(new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message))
  }
}

export default updateDailySummaryMiddleware