import { env } from '~/config/environment'
import { USER_MODEL } from '~/models/userModel'
import { StatusCodes } from 'http-status-codes'
import ApiError from '~/utils/ApiError'
import bcrypt from 'bcrypt'
import jsonwebtoken from 'jsonwebtoken'


const createNew = async (req, res, next) => {
  try {
    const { username, email, password } = req.body

    //Check if username and email already exists
    const usernameExists = await USER_MODEL.findOneByUsername(username)
    const emailExists = await USER_MODEL.findOneByEmail(email)
    if (usernameExists) {
      return next(new ApiError(StatusCodes.CONFLICT, 'Username already exists'))
    }
    if (emailExists) {
      return next(new ApiError(StatusCodes.CONFLICT, 'Email already exists'))
    }

    //Hash password before saving to database
    const hashedPassword = await bcrypt.hash(password, 10)

    const newUser = {
      username,
      email,
      password: hashedPassword,
      first_name: null,
      last_name: null,
      date_of_birth: null,
      gender: null,
      weight: null,
      height: null,
      emergency_contact: null
    }

    const createdUser = await USER_MODEL.createNewUser(newUser)
    const getNewUser = await USER_MODEL.findOneById(createdUser.insertedId)

    res.status(StatusCodes.OK).json({
      message: 'User created successfully',
      user: getNewUser })
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

const getProfile = async (req, res, next) => {
  try {
    const userId = req.user.id
    const user = await USER_MODEL.findOneById(userId)
    if (!user) {
      return next(new ApiError(StatusCodes.NOT_FOUND, 'User not found'))
    }
    delete user.password
    return res.status(StatusCodes.OK).json({
      message: 'User profile retrieved successfully',
      user: user
    })
  }
  catch (error) {
    next(new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message))
  }
}

export const userController = {
  createNew,
  findOneByUsername,
  login,
  getProfile
}