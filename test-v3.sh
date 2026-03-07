#!/usr/bin/env bash
set -e

PASS_COUNT=0
FAIL_COUNT=0
SERVER_PID=""
TEST_PORT="${TEST_PORT:-18080}"

fail() {
  echo "FAIL: $1"
  FAIL_COUNT=$((FAIL_COUNT+1))
}

pass() {
  echo "PASS: $1"
  PASS_COUNT=$((PASS_COUNT+1))
}

cleanup() {
  if [[ -n "${SERVER_PID}" ]]; then
    kill "${SERVER_PID}" 2>/dev/null || true
    wait "${SERVER_PID}" 2>/dev/null || true
    SERVER_PID=""
  fi
}
trap cleanup EXIT

# Build if needed
cd "$(dirname "$0")"

if [ -f build.sh ]; then
  bash build.sh 2>/dev/null || true
fi
chmod +x minihttp 2>/dev/null || true

######################################
# Start server
######################################

./minihttp serve --port "${TEST_PORT}" > /tmp/minihttp-test-output.txt 2>&1 &
SERVER_PID=$!

# Wait for "Listening on port" with 10s timeout
READY=0
for i in $(seq 1 100); do
  if grep -q "Listening on port" /tmp/minihttp-test-output.txt 2>/dev/null; then
    READY=1
    break
  fi
  sleep 0.1
done

if [[ "${READY}" -eq 0 ]]; then
  echo "FATAL: server did not print 'Listening on port' within 10s"
  exit 1
fi

BASE="http://localhost:${TEST_PORT}"

######################################
# Test 1: GET /hello
######################################

RESP=$(curl -s -w "\n%{http_code}" "${BASE}/hello")
BODY=$(echo "${RESP}" | head -1)
CODE=$(echo "${RESP}" | tail -1)

if [[ "${CODE}" == "200" ]] && [[ "${BODY}" == "Hello, World!" ]]; then
  pass "GET /hello returns 200 Hello, World!"
else
  fail "GET /hello returns 200 Hello, World! (got ${CODE}: ${BODY})"
fi

######################################
# Test 2: GET /echo with msg param
######################################

RESP=$(curl -s -w "\n%{http_code}" "${BASE}/echo?msg=hello")
BODY=$(echo "${RESP}" | head -1)
CODE=$(echo "${RESP}" | tail -1)

if [[ "${CODE}" == "200" ]] && [[ "${BODY}" == "hello" ]]; then
  pass "GET /echo?msg=hello returns 200 hello"
else
  fail "GET /echo?msg=hello returns 200 hello (got ${CODE}: ${BODY})"
fi

######################################
# Test 3: GET /echo with spaces in msg
######################################

RESP=$(curl -s -w "\n%{http_code}" "${BASE}/echo?msg=hello+world")
BODY=$(echo "${RESP}" | head -1)
CODE=$(echo "${RESP}" | tail -1)

if [[ "${CODE}" == "200" ]] && [[ "${BODY}" == "hello world" ]]; then
  pass "GET /echo?msg=hello+world returns decoded value"
else
  fail "GET /echo?msg=hello+world returns decoded value (got ${CODE}: ${BODY})"
fi

######################################
# Test 4: GET /echo without msg
######################################

RESP=$(curl -s -w "\n%{http_code}" "${BASE}/echo")
BODY=$(echo "${RESP}" | head -1)
CODE=$(echo "${RESP}" | tail -1)

if [[ "${CODE}" == "400" ]]; then
  pass "GET /echo without msg returns 400"
else
  fail "GET /echo without msg returns 400 (got ${CODE}: ${BODY})"
fi

######################################
# Test 5: POST /echo with body
######################################

RESP=$(curl -s -w "\n%{http_code}" -X POST -d "test body" "${BASE}/echo")
BODY=$(echo "${RESP}" | head -1)
CODE=$(echo "${RESP}" | tail -1)

if [[ "${CODE}" == "200" ]] && [[ "${BODY}" == "test body" ]]; then
  pass "POST /echo returns request body"
else
  fail "POST /echo returns request body (got ${CODE}: ${BODY})"
fi

######################################
# Test 6: POST /echo with empty body
######################################

RESP=$(curl -s -w "\n%{http_code}" -X POST -d "" "${BASE}/echo")
BODY=$(echo "${RESP}" | head -1)
CODE=$(echo "${RESP}" | tail -1)

if [[ "${CODE}" == "200" ]]; then
  pass "POST /echo with empty body returns 200"
else
  fail "POST /echo with empty body returns 200 (got ${CODE}: ${BODY})"
fi

######################################
# Test 7: 404 for unknown path
######################################

RESP=$(curl -s -w "\n%{http_code}" "${BASE}/unknown")
CODE=$(echo "${RESP}" | tail -1)

if [[ "${CODE}" == "404" ]]; then
  pass "unknown path returns 404"
else
  fail "unknown path returns 404 (got ${CODE})"
fi

######################################
# Test 8: server stays alive after multiple requests
######################################

curl -s "${BASE}/hello" > /dev/null
curl -s "${BASE}/hello" > /dev/null
RESP=$(curl -s -w "\n%{http_code}" "${BASE}/hello")
CODE=$(echo "${RESP}" | tail -1)

if [[ "${CODE}" == "200" ]]; then
  pass "server stays alive after multiple requests"
else
  fail "server stays alive after multiple requests (got ${CODE})"
fi

######################################
# Test 9: Content-Type is text/plain
######################################

CT=$(curl -s -I "${BASE}/hello" | grep -i "content-type" | head -1)
if echo "${CT}" | grep -qi "text/plain"; then
  pass "GET /hello Content-Type is text/plain"
else
  fail "GET /hello Content-Type is text/plain (got: ${CT})"
fi

######################################
# Test 10: GET /echo with percent-encoded msg
######################################

RESP=$(curl -s -w "\n%{http_code}" "${BASE}/echo?msg=foo%20bar")
BODY=$(echo "${RESP}" | head -1)
CODE=$(echo "${RESP}" | tail -1)

if [[ "${CODE}" == "200" ]] && [[ "${BODY}" == "foo bar" ]]; then
  pass "GET /echo?msg=foo%20bar returns decoded value"
else
  fail "GET /echo?msg=foo%20bar returns decoded value (got ${CODE}: ${BODY})"
fi

######################################
# Results
######################################

echo ""
echo "Results: ${PASS_COUNT} passed, ${FAIL_COUNT} failed"

if [[ "${FAIL_COUNT}" -gt 0 ]]; then
  exit 1
fi
exit 0
