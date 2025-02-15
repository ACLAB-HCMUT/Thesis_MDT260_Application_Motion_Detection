import { StatusCodes } from 'http-status-codes'
import Joi from 'joi'
import ApiError from '~/utils/ApiError'

const userRegister = Joi.object({
  username: Joi.string().required(),
  email: Joi.string().email().required(),
  password: Joi.string().required(),
  first_name: Joi.string().optional().allow(null),
  last_name: Joi.string().optional().allow(null),
  date_of_birth: Joi.date().optional().allow(null),
  gender: Joi.string().optional().allow(null),
  weight: Joi.number().optional().allow(null),
  height: Joi.number().optional().allow(null),
  emergency_contact: Joi.object({
    name: Joi.string().optional().allow(null),
    relationship: Joi.string().optional().allow(null),
    contact_number: Joi.string().optional().allow(null),
    email: Joi.string().email().optional().allow(null)
  }).optional().allow(null)
})

const userLogin = Joi.object({
  emailOrUsername: Joi.string().required(),
  password: Joi.string().required()
})

const createNew = async (req, res, next) => {
  try {
    //Set abortEarly to false to display all errors
    await userRegister.validateAsync(req.body, { abortEarly: false })
    //If no error, proceed to the next middleware
    next()
  } catch (error) {
    next(new ApiError(StatusCodes.BAD_REQUEST, new Error(error).message))
  }

}

const login = async (req, res, next) => {
  try {
    await userLogin.validateAsync(req.body, { abortEarly: false })
    next()
  } catch (error) {
    next(new ApiError(StatusCodes.BAD_REQUEST, new Error(error).message))
  }
}

export const userValidation = {
  createNew,
  login
}