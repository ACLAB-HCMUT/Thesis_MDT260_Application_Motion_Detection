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
      //Group activities by minute
      const activitiesByMinute = activitiesForDate.reduce((grouped, activity) => {
        const minute = new Date(activity.timestamp).toISOString().slice(0, 16) // Extract the minute (YYYY-MM-DDTHH:mm)
        if (!grouped[minute]) {
          grouped[minute] = []
        }
        grouped[minute].push(activity)
        return grouped
      }, {})

      // Calculate total time spent in each activity type for the date
      const totalTime = { walking: 0, running: 0, stepping_stair: 0, idle: 0 } //Init totalTime in seconds
      for (const [minute, activitiesInMinute] of Object.entries(activitiesByMinute)) {
        // Count occurrences of each activity in the minute
        const activityCounts = activitiesInMinute.reduce((counts, activity) => {
          counts[activity.activity] = (counts[activity.activity] || 0) + 1
          return counts
        }, {})

        // Determine the most frequent activity in the minute
        const dominantActivity = Object.keys(activityCounts).reduce((a, b) =>
          activityCounts[a] > activityCounts[b] ? a : b
        )

        // Add 60 seconds (1 minute) to the total time for the dominant activity
        totalTime[dominantActivity] += 60
      }


      // Calculate total calories burned for the date
      const totalCalories = activitiesForDate.reduce((sum, activity) => sum + calculateCalories(activity), 0)

      // Calculate total steps for the date
      const totalSteps = activitiesForDate.reduce((sum, activity) => sum + activity.steps, 0)

      // Update or create the daily summary for the user and date
      await DAILY_SUMMARY_MODEL.updateOrCreateDailySummary(
        userId,
        new Date(date).toISOString().split('T')[0],
        totalCalories,
        totalSteps, {
          totalWalkingTime: totalTime.walking / 3600, // Convert seconds to hours
          totalRunningTime: totalTime.running / 3600,
          totalSteppingStairTime: totalTime.stepping_stair / 3600,
          totalIdleTime: totalTime.idle / 3600
        })
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