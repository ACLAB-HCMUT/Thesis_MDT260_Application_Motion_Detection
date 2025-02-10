import { StatusCodes } from 'http-status-codes'
import Joi from 'joi'
import ApiError from '~/utils/ApiError'

const userRegister = Joi.object({
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