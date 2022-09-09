# newspack-docker
Nespack helper Repository  for running local environments using Docker

## Getting started

### Clone this repository

```BASH
git clone https://github.com/leogermani/newspack-docker.git
```

### Set up your local vars

Make a copy of `default.env` to `.env`

```BASH
cp default.env .env
```

Edit the file and choose your own variables

You can change the password and username of your WordPress user.

Linux users might want to configure apache to run as the same user as the host machine. You can do that in this file

### Build the Docker image

You only need to run this the first time you set up your env.

```BASH
./build-image.sh
```

### Clone all repos

This will clone all Newspack repos inside the `repos` folder

```BASH
./clone-repos.sh
```

### Lauch the container and install WordPress

Now we are going to use the `n` script. (Tip: Create an alias in your `.bashrc` so you can call it from anywhere)

#### Launch the container
```BASH
n start
```

When you are done, you can stop the containers with `n stop`.

At this point you should be able to see your site in `http://localhost`.

#### Install WordPress
```BASH
n install
```

#### Build the projects

The first time you set up your environment you might want to build all the project. You can do this by:

```BASH
n build all
```

## The N script

The `n` script will help you perform actions inside the containers. Some examples:

Build one specific project:

```BASH
n build theme
n build newspack-plugin
n build newsletters
```

Watch projects:

```BASH
n watch theme
n watch newspack-plugin
n watch newsletters
```

Run tests:

```BASH
n test-php plugin
n test-js plugin
```

Run WP CLI interactive shell

```BASH
n shell
```

Enter the container bash

```BASH
n sh # as the apache user, if USE_CUSTOM_APACHE_USER was set in your .env
n rsh # as root
```