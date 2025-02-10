import 'dotenv/config'

// Environment variables
export const env = {
  MONGODB_URI: process.env.MONGODB_URI,
  DATABASE_NAME: process.env.DATABASE_NAME,

  APP_HOST : process.env.APP_HOST,
  APP_PORT : process.env.APP_PORT,

  BUILD_MODE : process.env.BUILD_MODE,

  ACCESSTOKEN_SECRET : process.env.ACCESSTOKEN_SECRET,
  REFRESHTOKEN_SECRET : process.env.REFRESHTOKEN_SECRET,

  AUTHOR : process.env.AUTHOR
}