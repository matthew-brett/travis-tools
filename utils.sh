# Tools for working with travis-ci
WHEELHOSTS="travis-wheels.scikit-image.org travis-dev-wheels.scipy.org"

PIP_FLAGS="--timeout=60 --no-index"

for host in $WHEELHOSTS; do
   PIP_FLAGS="${PIP_FLAGS} --trusted-host ${host} --find-links=http://${host}"
done

function check_var {
    if [ -z "$1" ]; then
        echo "required variable not defined"
        exit 1
    fi
}

retry () {
    # https://gist.github.com/fungusakafungus/1026804
    local retry_max=5
    local count=$retry_max
    while [ $count -gt 0 ]; do
        "$@" && break
        count=$(($count - 1))
        sleep 1
    done

    [ $count -eq 0 ] && {
        echo "Retry failed [$retry_max]: $@" >&2
        return 1
    }
    return 0
}


wheelhouse_pip_install() {
    # Install pip requirements via travis wheelhouse
    retry pip install $PIP_FLAGS $@
}


travis_before_install () {
    # If DEPENDS defined, install packages named in DEPENDS
    # If COVERAGE defined, install coverage / coveralls
    # If EXTRA_PIP_FLAGS defined, pass to pip install
    virtualenv --python=python venv
    source venv/bin/activate
    python --version # just to check
    python -m pip install --upgrade pip
    pip install --upgrade wheel
    if [ -n "$DEPENDS" ]; then
        wheelhouse_pip_install $EXTRA_PIP_FLAGS $DEPENDS
    fi
    if [ "${COVERAGE}" == "1" ]; then
        pip install coverage;
        pip install coveralls;
    fi
}


travis_install () {
    # Takes single argument, string, install_type
    # If EXTRA_PIP_FLAGS defined, pass to pip install
    local install_type=$1
    if [ -z "$install_type" ]; then
        install_type="pip-dev"
    fi
    if [ "$install_type" == "pip-dev" ]; then
        pip install $EXTRA_PIP_FLAGS -e .
    elif [ "$install_type" == "setup" ]; then
        python setup.py install
    elif [ "$install_type" == "sdist" ]; then
        python setup.py egg_info  # check egg_info while we're here
        python setup.py sdist
        wheelhouse_pip_install $EXTRA_PIP_FLAGS dist/*.tar.gz
    elif [ "$install_type" == "wheel" ]; then
        pip install wheel
        python setup.py bdist_wheel
        wheelhouse_pip_install $EXTRA_PIP_FLAGS dist/*.whl
    elif [ "$install_type" == "requirements" ]; then
        wheelhouse_pip_install $EXTRA_PIP_FLAGS -r requirements.txt
        python setup.py install
    else
        echo "Funny install type ${install_type}"
    fi
}
