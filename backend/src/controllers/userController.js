import { USER_MODEL } from '~/models/userModel'
import { StatusCodes } from 'http-status-codes'
import ApiError from '~/utils/ApiError'

const createNew = async (req, res, next) => {
  try {
    const newUser = { ...req.body }

    const createdUser = await USER_MODEL.createNewUser(newUser)
    const getNewUser = await USER_MODEL.findOneById(createdUser.insertedId)

    res.status(StatusCodes.OK).json(getNewUser)
  } catch (error) {
    throw new Error(error)
  }
}

const login = async (req, res, next) => {
  try {
    const { email, password } = req.body
    const user = await USER_MODEL.findOneByEmail(email)

    if (user) {
      res.status(StatusCodes.OK).json(user)
    }
    else {
      res.status(StatusCodes.NOT_FOUND).json({ message: 'User not found' })
    }
  } catch (error) {
    throw new Error(error)
  }
}

const findOneByUsername = async (username) => {
  try {
    const user = await USER_MODEL.findOneByUsername(username)
    if (!user) {
      throw new ApiError(StatusCodes.NOT_FOUND, 'User not found')
    }
    return user
  } catch (error) {
    throw new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message)
  }
}

const findOneByEmail = async (req, res, next) => {
  try {
    const { email } = req.params
    const user = await USER_MODEL.findOneByEmail(email)
    if (user) {
      res.status(StatusCodes.OK).json(user)
    } else {
      res.status(StatusCodes.NOT_FOUND).json({ message: 'User not found' })
    }
  } catch (error) {
    next(new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message))
  }
}

export const userController = {
  createNew,
  findOneByUsername,
  findOneByEmail,
  login
}