import Joi from 'joi'
import { OBJECT_ID_RULE, OBJECT_ID_RULE_MESSAGE } from '~/utils/validators'
import { GET_DB } from '~/config/mongodb'
import { ObjectId } from 'mongodb'

const USER_COLLECTION_NAME = 'users'
const USER_SCHEMA = Joi.object({
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
  }).optional(),
  createdAt: Joi.date().timestamp('javascript').default,
  updatedAt: Joi.date().timestamp('javascript').default,
  _destroy: Joi.boolean().default(false)
})

const validateUser = async (data) => {
  return await USER_SCHEMA.validateAsync(data, { abortEarly: false })
}

const createNewUser = async (data) => {
  try {
    const validatedData = await validateUser(data)
    return await GET_DB().collection(USER_COLLECTION_NAME).insertOne(validatedData)
  } catch (error) {
    throw new Error(error)
  }
}

const findOneById = async (id) => {
  try {
    return await GET_DB().collection(USER_COLLECTION_NAME).findOne({
      _id: new ObjectId(String(id))
    })
  } catch (error) {
    throw new Error(error)
  }
}

const findOneByUsername = async (username) => {
  try {
    return await GET_DB().collection(USER_COLLECTION_NAME).findOne({
      username
    })
  } catch (error) {
    throw new Error(error)
  }
}

const findOneByEmail = async (email) => {
  try {
    const user = await GET_DB().collection(USER_COLLECTION_NAME).findOne({ email })
    return user
  } catch (error) {
    throw new Error(error)
  }
}

export const USER_MODEL = {
  USER_COLLECTION_NAME,
  USER_SCHEMA,
  createNewUser,
  findOneById,
  findOneByUsername,
  findOneByEmail
}