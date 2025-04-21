import { DAILY_SUMMARY_MODEL } from '~/models/dailySummaryModel.js'
import ApiError from '~/utils/ApiError'
import { StatusCodes } from 'http-status-codes'
import calculateCalories from '~/utils/calculateCalories.js'

const updateDailySummaryMiddleware = async (req, res, next) => {
  try {
    const userId = req.user.id //Extract userId from the request object

    const activities = req.activities // Use activities passed from the controller

    if (!activities || activities.length === 0) {
      return res.status(StatusCodes.OK).json({ message: 'No activities found to process.', activities: [] })
    }

    // Group activities by date
    const activitiesByDate = activities.reduce((grouped, activity) => {
      const date = new Date(activity.timestamp).toISOString().split('T')[0] // Extract the date (YYYY-MM-DD)
      if (!grouped[date]) {
        grouped[date] = []
      }
      grouped[date].push(activity)
      return grouped
    }, {})

    // Process each date group
    for (const [date, activitiesForDate] of Object.entries(activitiesByDate)) {
      // Calculate total calories burned for the date
      const totalCalories = activitiesForDate.reduce((sum, activity) => sum + calculateCalories(activity), 0)

      // Update or create the daily summary for the user and date
      await DAILY_SUMMARY_MODEL.updateOrCreateDailySummary(userId, date, activitiesForDate, totalCalories)
    }
    return res.status(StatusCodes.CREATED).json({
      status: 'success',
      message: 'Activities submitted and daily summary updated successfully',
      data: activities
    })

  } catch (error) {
    next(new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message))
  }
}

export default updateDailySummaryMiddleware