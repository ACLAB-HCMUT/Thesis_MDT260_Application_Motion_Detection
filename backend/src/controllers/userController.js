import { env } from '~/config/environment'
import { USER_MODEL } from '~/models/userModel'
import { StatusCodes } from 'http-status-codes'
import ApiError from '~/utils/ApiError'
import bcrypt from 'bcrypt'
import jsonwebtoken from 'jsonwebtoken'


const createNew = async (req, res, next) => {
  try {
    const { full_name, username, email, password } = req.body

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
      full_name,
      password: hashedPassword,
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

const editProfile = async (req, res, next) => {
  try {
    const userId = req.user.id
    const user = await USER_MODEL.findOneById(userId)

    if (!user) {
      return next(new ApiError(StatusCodes.NOT_FOUND, 'User not found'))
    }

    const { full_name, date_of_birth, gender, weight, height } = req.body

    //If no changes are detected, respond with a bad request error
    if (!full_name && !date_of_birth && !gender && !weight && !height) {
      return next(new ApiError(StatusCodes.BAD_REQUEST, 'No changes detected'))
    }

    //Update the user profile if they are provided
    if (full_name !== undefined) user.full_name = full_name
    if (date_of_birth !== undefined) user.date_of_birth = date_of_birth
    if (gender !== undefined) user.gender = gender
    if (weight !== undefined) user.weight = weight
    if (height !== undefined) user.height = height

    //Update updatedAt field to current date
    user.updatedAt = new Date()

    await USER_MODEL.updateUser(user)
    return res.status(StatusCodes.OK).json({
      message: 'User profile updated successfully',
      user: user
    })

  } catch (error) {
    next(new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message))
  }
}

const updateLoginInfo = async (req, res, next) => {
  try {
    const userId = req.user.id
    const user = await USER_MODEL.findOneById(userId)

    if (!user) {
      return next(new ApiError(StatusCodes.NOT_FOUND, 'User not found'))
    }

    const { username, email, newPassword, currentPassword } = req.body

    //If no changes are detected, respond with a bad request error
    if (!username && !email && !newPassword) {
      return next(new ApiError(StatusCodes.BAD_REQUEST, 'No changes detected'))
    }

    //Check if current password is provided and valid
    if (currentPassword !== undefined) {
      const isCurrentPasswordValid = await bcrypt.compare(currentPassword, user.password)
      if (!isCurrentPasswordValid) {
        return next(new ApiError(StatusCodes.UNAUTHORIZED, 'Invalid password'))
      }
    } else {
      return next(new ApiError(StatusCodes.BAD_REQUEST, 'Current password is required'))
    }

    //Check for username conflicts
    if (username !== undefined && username !== user.username) {
      const usernameExists = await USER_MODEL.findOneByUsername(username)
      if (usernameExists) {
        return next(new ApiError(StatusCodes.CONFLICT, 'Username already exists'))
      }
      user.username = username //Update the username if provided and not already taken
    }

    if (email !== undefined && email !== user.email) {
      const emailExists = await USER_MODEL.findOneByEmail(email)
      if (emailExists) {
        return next(new ApiError(StatusCodes.CONFLICT, 'Email already exists'))
      }
      user.email = email //Update the email if provided and not already taken
    }

    if (newPassword !== undefined && newPassword.length < 8) {
      return next(new ApiError(StatusCodes.BAD_REQUEST, 'Password must be at least 8 characters long'))
    }

    if (newPassword !== undefined) {
      if (await bcrypt.compare(newPassword, user.password)) {
        return next(new ApiError(StatusCodes.BAD_REQUEST, 'New password must be different from the current password'))
      }
      const hashedPassword = await bcrypt.hash(newPassword, 10)
      user.password = hashedPassword
    }

    //Update updatedAt field to current date
    user.updatedAt = new Date()

    await USER_MODEL.updateUser(user)
    return res.status(StatusCodes.OK).json({
      message: 'User login info updated successfully',
      user: user
    })

  } catch (error) {
    next(new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, error.message))
  }
}

export const userController = {
  createNew,
  findOneByUsername,
  login,
  getProfile,
  editProfile,
  updateLoginInfo
}