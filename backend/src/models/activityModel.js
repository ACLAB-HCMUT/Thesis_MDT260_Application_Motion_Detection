import Joi from 'joi'
import { OBJECT_ID_RULE, OBJECT_ID_RULE_MESSAGE } from '~/utils/validators'

const ACTIVITY_COLLECTION_NAME = 'activities'
const ACTIVITY_SCHEMA = Joi.object({
  userId: Joi.string().required().pattern(OBJECT_ID_RULE).message(OBJECT_ID_RULE_MESSAGE),
  timestamp: Joi.date().required(),
  activity: Joi.string().valid('running', 'walking', 'stair_climbing', 'idle').required(),
  steps: Joi.number().integer().min(0).required(),
  createdAt: Joi.date().default(() => new Date())
})

export { ACTIVITY_COLLECTION_NAME, ACTIVITY_SCHEMA }