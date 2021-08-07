//const cubes = document.querySelectorAll('.cubeWrapper');
const cubes = document.querySelectorAll('[fadeIn]');


observer = new IntersectionObserver(entries => {
  entries.forEach(entry => {
    const square = entry.target.querySelector('.match');

    if (entry.isIntersecting) {
        square.classList.add('slide-in-blurred-bottom');
	  return; // if we added the class, exit the function
    }

    // We're not intersecting, so remove the class!
    square.classList.remove('slide-in-blurred-bottom');
  });
});

cubes.forEach(cube => {
	observer.observe(cube);
});