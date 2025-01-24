import Joi from 'joi'
import { OBJECT_ID_RULE, OBJECT_ID_RULE_MESSAGE } from '~/utils/validators'

const DAILY_SUMMARY_COLLECTION_NAME = 'dailySummaries'
const DAILY_SUMMARY_SCHEMA = Joi.object({
  daily_summary_id: Joi.string().required().pattern(OBJECT_ID_RULE).message(OBJECT_ID_RULE_MESSAGE),
  user_id: Joi.string().required().pattern(OBJECT_ID_RULE).message(OBJECT_ID_RULE_MESSAGE),
  date: Joi.date().required(),
  total_steps: Joi.number().required(),
  total_calories_burned: Joi.number().required(),
  total_distances: Joi.number().required()
})

export { DAILY_SUMMARY_COLLECTION_NAME, DAILY_SUMMARY_SCHEMA }