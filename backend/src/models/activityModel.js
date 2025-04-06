import Joi from 'joi'
import { GET_DB } from '~/config/mongodb'
import { OBJECT_ID_RULE, OBJECT_ID_RULE_MESSAGE } from '~/utils/validators'

const ACTIVITY_COLLECTION_NAME = 'activities'
const ACTIVITY_SCHEMA = Joi.object({
  userId: Joi.string().required().pattern(OBJECT_ID_RULE).message(OBJECT_ID_RULE_MESSAGE),
  timestamp: Joi.date().required(),
  activity: Joi.string().valid('running', 'walking', 'stair_climbing', 'idle').required(),
  steps: Joi.number().integer().min(0).required(),
  caloriesBurned: Joi.number().optional().allow(null),
  createdAt: Joi.date().default(() => new Date())
})

const validateActivity = async (data) => {
  return await ACTIVITY_SCHEMA.validateAsync(data, { abortEarly: false })
}

const createNewActivities = async (activities) => {
  try {
    //Validate each activity in the data array
    const validatedActivities = await Promise.all(
      activities.map(activity => validateActivity(activity))
    )

    //Insert the validated activities into the database
    return await GET_DB().collection(ACTIVITY_COLLECTION_NAME).insertMany(validatedActivities)
  } catch (error) {
    throw new Error(error)
  }
}

export const ACTIVITY_MODEL = {
  ACTIVITY_COLLECTION_NAME,
  ACTIVITY_SCHEMA,
  createNewActivities
}