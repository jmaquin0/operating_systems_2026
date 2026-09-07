function changeText() {
    const element = document.getElementById('myText');
    element.textContent = 'Text changed!';
}

window.onload = function() {
    setTimeout(changeText, 3000);
};
