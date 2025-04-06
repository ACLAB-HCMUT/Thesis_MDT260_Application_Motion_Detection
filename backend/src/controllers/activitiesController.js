import { USER_MODEL } from '~/models/userModel'
import { StatusCodes } from 'http-status-codes'
import { ACTIVITY_MODEL } from '~/models/activityModel'
import ApiError from '~/utils/ApiError'

const submitActivities = async (req, res, next) => {
  try {
    const userId = req.user.id
    const user = await USER_MODEL.findOneById(userId)

    if (!user) {
      return next(new ApiError(StatusCodes.NOT_FOUND, 'User not found'))
    }

    const { data } = req.body
    if (!data || data.length === 0 || !Array.isArray(data)) {
      return next(new ApiError(StatusCodes.BAD_REQUEST, 'No valid data provided'))
    }

    //Map the data to include the userId to each activity
    const activities = data.map((activity) => ({
      userId: userId,
      ...activity
    }))

    //Store the activities in the database
    await ACTIVITY_MODEL.createNewActivities(activities)

    return res.status(StatusCodes.CREATED).json({
      status: 'success',
      message: 'Activities submitted successfully',
      data: activities
    })
  } catch (error) {
    return next(new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message))
  }
}

export const activitesController = {
  submitActivities
}