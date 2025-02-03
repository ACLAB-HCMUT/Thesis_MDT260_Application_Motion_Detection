import { slugify } from '~/utils/formatter'
import { USER_MODEL } from '~/models/userModel'

const createNew = async(reqBody) => {
  try {
    const newUser = {
      ...reqBody,
      slug: slugify(reqBody.title)
    }

    const createdUser = await USER_MODEL.createNewUser(newUser)

    const getNewUser = await USER_MODEL.findOneById(createdUser.insertedId)

    return getNewUser
  } catch (error) {
    throw new Error(error)
  }
}

export const userService = {
  createNew
}