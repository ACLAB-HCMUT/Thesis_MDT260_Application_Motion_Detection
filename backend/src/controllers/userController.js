import { env } from '~/config/environment'
import { USER_MODEL } from '~/models/userModel'
import { StatusCodes } from 'http-status-codes'
import ApiError from '~/utils/ApiError'
import bcrypt from 'bcrypt'
import jsonwebtoken from 'jsonwebtoken'

const createNew = async (req, res, next) => {
  try {
    const newUser = { ...req.body }

    //Hash password before saving to database
    const hashedPassword = await bcrypt.hash(newUser.password, 10)
    newUser.password = hashedPassword

    const createdUser = await USER_MODEL.createNewUser(newUser)
    const getNewUser = await USER_MODEL.findOneById(createdUser.insertedId)

    res.status(StatusCodes.OK).json(getNewUser)
  } catch (error) {
    next(new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message))
  }
}

const login = async (req, res, next) => {
  try {
    const { email, password } = req.body
    const user = await USER_MODEL.findOneByEmail(email)

    if (!user) {
      return next(new ApiError(StatusCodes.UNAUTHORIZED, 'User not found'))
    }

    //Compare the provided password with the hashed password in the database
    const isPasswordValid = await bcrypt.compare(password, user.password)
    if (!isPasswordValid) {
      return next(new ApiError(StatusCodes.UNAUTHORIZED, 'Invalid password'))
    }

    //Generate token
    const accessToken = jsonwebtoken.sign({ id: user._id }, env.ACCESSTOKEN_SECRET, { expiresIn: '1h' })
    const refreshToken = jsonwebtoken.sign({ id: user._id }, env.REFRESHTOKEN_SECRET, { expiresIn: '7d' })

    res.status(StatusCodes.OK).json({
      statusCode: StatusCodes.OK,
      message: 'Login successful',
      token: accessToken
    })
  } catch (error) {
    next(new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message))
  }
}

const findOneByUsername = async (username, next) => {
  try {
    const user = await USER_MODEL.findOneByUsername(username)
    if (!user) {
      return next(new ApiError(StatusCodes.NOT_FOUND, 'User not found'))
    }
    return user
  } catch (error) {
    return next(new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message))
  }
}

export const userController = {
  createNew,
  findOneByUsername,
  login
}