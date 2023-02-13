# newspack-docker
Newspack helper Repository for running local environments using Docker.

The main idea is to have all the dependecies we need to run the projects, and its tests, inside the container so we don't depend on anything in our local machine.
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

(You can also call `./build-image-8.sh` or `./build-image-81.sh` to build an image with PHP 8.0 or 8.1 instead of 7.4. It's a good idea to have both)

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

(`n start8` or `n start81` will start the image with php 8.0 or 8.1 if you built them)

When you are done, you can stop the containers with `n stop`.

At this point you should be able to see your site in `http://localhost`.

#### Install WordPress
```BASH
n install
```

#### Build the projects

The first time you set up your environment you might want to build all the projects. You can do this by:

```BASH
n build all
```

## The N script

The `n` script will help you perform actions inside the containers. Some examples:

Build one specific project:

```BASH
n build theme # Builds the newspack-theme repo
n build newspack-plugin # Builds the main plugin
n build newsletters # You can also omit the 'newspack-' prefix from plugins
```

Watch projects:

```BASH
n watch theme
n watch newspack-plugin
n watch newsletters
```

Run tests:

```BASH
n test-js plugin
n test-php plugin
n test-php plugin --filter=some_filter
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

Run composer commands inside one of the projects

```BASH
n composer plugin dump-autoload # Runs `composer dump-autload` inside the newspack-plugin repo
n composer theme update # Runs `composer update` inside the newspack-theme repo
```

Other commands:

* `n db`: Launches the MySQL interactive shell
* `n wp`: runs any arbitraty WP CLI command. e.g. `n wp option get blogname`
* `n tail`: Tails the apache error log file
* `n uninstall`: Uninstalls WordPress
* `jncp`, `jninit` & `secrets`: See Jurassic Ninja section below.
* `n secrets-import`: Import all your secrets from a `secrets.json` file (see details on the Jurassic Ninha section below)
* `n snapshot $name`: Creates a snapshot of the current site and gives it a name
* `n snapshot-load $name`: Drops the current site and override it with the data from a snapshot
* `n new-site`: Drops the current site and creates a new one from scratch
* `n pull`: Pull every git repository inside `repos/`

## Jurassic Ninja

There are some commands to help you work with Jurassic Ninja

### Initialize and Sets up a new JN Site
```BASH
n jninit user domain.jurassic.ninja
```

This command Sets up a new Jurassic Ninja site. It will
* Upload the newspack-plugin from your machine to JN
* Run `wp newspack setup`
* Copy your secrets to the JN site

**Setting up your Secrets**

If you want your secrets to be copied over to the JN site, create a `secrets.json` file inside the `bin` folder.

You can copy the `secrets.json.sample` file and manually edit it, or you can use `n secrets` to output the secrets you currently have on your local site.

If you want to directly copy the secrets into the file you can run `n secrets > bin/secrets.json`.

### Copy plugins to a JN Site
```BASH
n jncp user domain.jurassic.ninja
```

This command will allow you to copy one or many plugins from your local env to the JN site at once.

This is useful if you want to replace the plugin in the site with the custom branch you have checked out, or if you want to upload any other plugin you have.

## Mailhog

Mailhog is running by default so you can see all the emails that are sent from your WordPress site.

Visit http://localhost:8025 to see it.

## Adminer

Adminer is available at http://localhost:8088

Connect to Server `db`, user `root` and password defined in your local `.env` file.

## Memcached

By default, Memcached plugin is enabled. If you want to disable it, simply delete the `html/wp-content/object-cache.php` file.
