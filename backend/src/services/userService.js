import { slugify } from '~/utils/formatter'

const createNew = async(reqBody) => {
  try {
    const newUser = {
      ...reqBody,
      slug: slugify(reqBody.title)
    }
    return newUser
  } catch (error) {
    throw new Error(error)
  }
}

export const userService = {
  createNew
}