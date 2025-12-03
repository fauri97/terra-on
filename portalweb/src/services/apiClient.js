import axios from 'axios'

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:5078/'

let _authToken = null

export function setAuthToken(token) {
  _authToken = token
}

export function clearAuthToken() {
  _authToken = null
}

const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 15000,
})

api.interceptors.request.use(
  (config) => {
    if (config.useAuth && _authToken) {
      config.headers = config.headers || {}
      config.headers.Authorization = `Bearer ${_authToken}`
    }

    return config
  },
  (error) => Promise.reject(error),
)

function get(url, options = {}) {
  const { params, auth = false, ...rest } = options
  return api.get(url, { params, useAuth: auth, ...rest })
}

function post(url, data, options = {}) {
  const { params, auth = false, ...rest } = options
  return api.post(url, data, { params, useAuth: auth, ...rest })
}

function put(url, data, options = {}) {
  const { params, auth = false, ...rest } = options
  return api.put(url, data, { params, useAuth: auth, ...rest })
}

function patch(url, data, options = {}) {
  const { params, auth = false, ...rest } = options
  return api.patch(url, data, { params, useAuth: auth, ...rest })
}

function del(url, options = {}) {
  const { params, auth = false, ...rest } = options
  return api.delete(url, { params, useAuth: auth, ...rest })
}

export const apiClient = {
  get,
  post,
  put,
  patch,
  delete: del,
}

export default apiClient
