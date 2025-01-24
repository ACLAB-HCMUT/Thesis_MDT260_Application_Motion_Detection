import Joi from 'joi'
import { OBJECT_ID_RULE, OBJECT_ID_RULE_MESSAGE } from '~/utils/validators'

const EMERGENCY_CONTACT_COLLECTION_NAME = 'emergencyContacts'
const EMERGENCY_CONTACT_SCHEMA = Joi.object({
  user_id: Joi.string().required().pattern(OBJECT_ID_RULE).message(OBJECT_ID_RULE_MESSAGE),
  name: Joi.string().required(),
  relationship: Joi.string().required(),
  contact_number: Joi.string().required(),
  email: Joi.string().email().required()
})

export { EMERGENCY_CONTACT_COLLECTION_NAME, EMERGENCY_CONTACT_SCHEMA }