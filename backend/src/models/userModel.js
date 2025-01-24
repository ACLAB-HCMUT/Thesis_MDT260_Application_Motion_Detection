import Joi from 'joi'
import { OBJECT_ID_RULE, OBJECT_ID_RULE_MESSAGE } from '~/utils/validators'

const USER_COLLECTION_NAME = 'users'
const USER_SCHEMA = Joi.object({
  user_id: Joi.string().required().pattern(OBJECT_ID_RULE).message(OBJECT_ID_RULE_MESSAGE),
  username: Joi.string().required(),
  email: Joi.string().email().required(),
  password: Joi.string().required(),
  first_name: Joi.string().required(),
  last_name: Joi.string().required(),
  date_of_birth: Joi.date().required(),
  gender: Joi.string().required(),
  weight: Joi.number().required(),
  height: Joi.number().required(),
  emergency_contact: Joi.object({
    name: Joi.string().required(),
    relationship: Joi.string().required(),
    contact_number: Joi.string().required(),
    email: Joi.string().email().required()
  }).optional()
})

export { USER_COLLECTION_NAME, USER_SCHEMA }