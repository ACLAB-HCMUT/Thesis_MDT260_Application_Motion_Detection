# Description

This is the backend for the Thesis: Motion Detection Application project. It is built using Node.js and Express.

## Installation

To get started with this project, follow the steps below:

### Prerequisites

- Node.js (>= 18.x)
- Yarn (>= 1.x)

### Installing Node.js

To install Node.jsa on Windows: 

1. Download the installer from the [official Node.js website](https://nodejs.org/en/download)

2. Run the installer and follow the installation steps.

3. Verify the installation by opening a command prompt and running:

   ```sh
   node -v
   ```

### Installing Yarn

To install Yarn via npm on Windows:

1. Open a command prompt and run the following command:

   ```sh
   npm install --global yarn
   ```

2. Verify the installation by running:

   ```sh
   yarn -v
   ```


### Steps

1. Clone the repository:

   ```sh
   git clone https://github.com/ACLAB-HCMUT/Thesis_MDT260_Application_Motion_Detection.git
   cd backend

   ```

2. Install the dependencies:

```sh
yarn install
```

3. Create a .env file in the root directory and add the necessary environment variables. You can use the .env.example file as a reference.


4. Start the development server

The development server runs with `nodemon` and `babel-node`, which allows for automatic restarts and ES6+ support. It also shows detailed stack trace logs for easier debugging.

```sh
yarn dev
```

5. Start the production server

The production server runs the compiled code and does not show stack trace logs for errors, providing a cleaner output suitable for a production environment.

```sh
yarn production
```
