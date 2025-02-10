import Joi from 'joi'
import { OBJECT_ID_RULE, OBJECT_ID_RULE_MESSAGE } from '~/utils/validators'

const ACTIVITY_COLLECTION_NAME = 'activities'
const ACTIVITY_SCHEMA = Joi.object({
  activity_id: Joi.string().required().pattern(OBJECT_ID_RULE).message(OBJECT_ID_RULE_MESSAGE),
  daily_summary_id: Joi.string().required().pattern(OBJECT_ID_RULE).message(OBJECT_ID_RULE_MESSAGE),
  date: Joi.date().required(),
  activity_type: Joi.string().required(),
  start_time: Joi.date().iso().required(),
  end_time: Joi.date().iso().required(),
  metrics: Joi.object({
    steps: Joi.number().required(),
    distance: Joi.number().required(),
    calories_burned: Joi.number().required(),
    duration: Joi.number().required()
  }).required()
})

export { ACTIVITY_COLLECTION_NAME, ACTIVITY_SCHEMA }