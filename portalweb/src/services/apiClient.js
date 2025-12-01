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

function get(url, { params, auth = false } = {}) {
  return api.get(url, { params, useAuth: auth })
}

function post(url, data, { params, auth = false } = {}) {
  return api.post(url, data, { params, useAuth: auth })
}

function put(url, data, { params, auth = false } = {}) {
  return api.put(url, data, { params, useAuth: auth })
}

function patch(url, data, { params, auth = false } = {}) {
  return api.patch(url, data, { params, useAuth: auth })
}

function del(url, { params, auth = false } = {}) {
  return api.delete(url, { params, useAuth: auth })
}

export const apiClient = {
  get,
  post,
  put,
  patch,
  delete: del,
}

export default apiClient
