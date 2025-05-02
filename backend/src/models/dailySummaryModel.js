import Joi from 'joi'
import { GET_DB } from '~/config/mongodb'
import { OBJECT_ID_RULE, OBJECT_ID_RULE_MESSAGE } from '~/utils/validators'

const DAILY_SUMMARY_COLLECTION_NAME = 'dailySummaries'
const DAILY_SUMMARY_SCHEMA = Joi.object({
  user_id: Joi.string().required().pattern(OBJECT_ID_RULE).message(OBJECT_ID_RULE_MESSAGE),
  date: Joi.date().required(), // Date of the summary
  total_steps: Joi.number().min(0).required(), // Total steps taken on that date
  total_calories: Joi.number().required(), // Total calories burned on that date
  total_walking_time: Joi.number().min(0).default(0), // Total walking time in hours
  total_running_time: Joi.number().min(0).default(0), // Total running time in hours
  total_stepping_stair_time: Joi.number().min(0).default(0), // Total stepping stair time in hours
  total_idle_time: Joi.number().min(0).default(0), // Total idle time in hours
  createdAt: Joi.date().default(() => new Date()),
  updatedAt: Joi.date().default(() => new Date())
})

const validateDailySummary = async (data) => {
  return await DAILY_SUMMARY_SCHEMA.validateAsync(data, { abortEarly: false })
}

const createNewDailySummary = async (dailySummaryData) => {
  try {
    // Validate the daily summary data
    const validatedDailySummary = await validateDailySummary(dailySummaryData)

    // Insert the validated daily summary into the database
    return await GET_DB().collection(DAILY_SUMMARY_COLLECTION_NAME).insertOne(validatedDailySummary)
  } catch (error) {
    throw new Error(error)
  }
}

const updateDailySummary = async (userId, date, updateData) => {
  try {
    // Validate the update data
    const validatedUpdateData = await DAILY_SUMMARY_SCHEMA.validateAsync(updateData, { abortEarly: false })

    // Update the daily summary in the database
    return await GET_DB().collection(DAILY_SUMMARY_COLLECTION_NAME).updateOne(
      { user_id: userId, date },
      { $set: validatedUpdateData }
    )
  } catch (error) {
    throw new Error(error)
  }
}

const updateOrCreateDailySummary = async (userId, date, totalCalories, totalSteps, totalTimes) => {
  try {
    //Prepare the daily summary data
    const dailySummaryData = {
      user_id: userId,
      date: date,
      total_steps: totalSteps,
      total_calories: totalCalories || 0, // Use provided calories or default to 0
      total_walking_time: totalTimes.totalWalkingTime || 0,
      total_running_time: totalTimes.totalRunningTime || 0,
      total_stepping_stair_time: totalTimes.totalSteppingStairTime || 0,
      total_idle_time: totalTimes.totalIdleTime || 0,
      updatedAt: new Date()
    }

    //Check if a daily summary already exists for the user on the specified date
    const existingSummary = await GET_DB().collection(DAILY_SUMMARY_COLLECTION_NAME).findOne({
      user_id: userId,
      date
    })

    if (existingSummary) {
      //If it exists, update the existing summary
      await updateDailySummary(userId, date, dailySummaryData)
    }

    else {
      //If it doesn't exist, create a new summary
      await createNewDailySummary(dailySummaryData)
    }
  } catch (error) {
    throw new Error(error)
  }
}

export const DAILY_SUMMARY_MODEL = {
  DAILY_SUMMARY_COLLECTION_NAME,
  DAILY_SUMMARY_SCHEMA,
  createNewDailySummary,
  updateDailySummary,
  updateOrCreateDailySummary
}