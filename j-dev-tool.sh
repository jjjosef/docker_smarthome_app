#!/bin/bash
key=$1

echo $key

case  $key in
  "init")
	docker run -ti --rm -v /Users/JasonYang/Developer/docker-micro-vert-app:/myApp:rw micro-vert-app init.sh
	;;
  "build")
	docker run -ti --rm -v /Users/JasonYang/Developer/docker-micro-vert-app:/myApp:rw micro-vert-app build.sh
	;;
  "run")
	# docker run -ti --rm --net host --privileged --device=/dev/tty.usbmodem37bedab2:/dev/tty.usbmodem37bedab2 -v /Users/JasonYang/Developer/docker-micro-vert-app:/myApp:rw micro-vert-app run.sh
  docker run -ti --rm --tty -v /Users/JasonYang/Developer/docker-micro-vert-app:/myApp:rw micro-vert-app build.sh
  adb install -r ~/Developer/docker-micro-vert-app/platforms/android/build/outputs/apk/android-debug.apk
	;;
  *)
  echo "Wrong command."
	exit 1
	;;
esac   
