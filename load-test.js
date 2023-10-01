import http from 'k6/http';
import { sleep } from 'k6';

export let options = {
  stages: [
    { duration: '30s', target: 1000 }, // Ramp up to 1000 VUs over 30 seconds
    { duration: '30s', target: 1000 },  // Stay at 1000 VUs for 2 minutes
  ],
};

export default function () {
  // Make an HTTP GET request to your Go application's /fibonacci endpoint
  let response = http.get('https://epita-demo.padok.school/fibonacci');

  // Check if the response status code is 200
  if (response.status !== 200) {
    console.error(`Error - Status code ${response.status}: ${response.body}`);
  }

  // Sleep for a short duration between requests (e.g., 1 second)
  //sleep(1);
}
