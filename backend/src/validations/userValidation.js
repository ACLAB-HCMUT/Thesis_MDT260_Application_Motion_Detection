import { StatusCodes } from 'http-status-codes'
import Joi from 'joi'
import ApiError from '~/utils/ApiError'

const createNew = async (req, res, next) => {
  const correctCondition = Joi.object({
    title: Joi.string().required().min(3).max(50).trim().strict().messages({
      'any.required': 'Title is required',
      'string.base': 'Title should be a type of text',
      'string.empty': 'Title should not be empty',
      'string.min': 'Title should have a minimum length of 3',
      'string.max': 'Title should have a maximum length of 50',
      'string.trim': 'Title should not have leading or trailing spaces'
    }),
    description: Joi.string().required().min(3).max(50).trim().strict().messages({
      'any.required': 'Description is required',
      'string.base': 'Description should be a type of text',
      'string.empty': 'Description should not be empty',
      'string.min': 'Description should have a minimum length of 3',
      'string.max': 'Description should have a maximum length of 50',
      'string.trim': 'Description should not have leading or trailing spaces'
    })
  })

  try {
    //Set abortEarly to false to display all errors
    await correctCondition.validateAsync(req.body, { abortEarly: false })
    //If no error, proceed to the next middleware
    next()
  } catch (error) {
    next(new ApiError(StatusCodes.BAD_REQUEST, new Error(error).message))
  }

}

export const userValidation = {
  createNew
}