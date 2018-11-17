import matplotlib.pyplot as plt
from matplotlib.patches import Ellipse
import scipy.stats
import scipy.linalg
import numpy as np

def eigsorted(cov):
    vals, vecs = np.linalg.eigh(cov)
    order = vals.argsort()[::-1]
    return vals[order], vecs[:,order]

def plot_ellipse(mean, sigma, color, scale_factor):
    eigenvalues, eigenvectors = eigsorted(sigma)
    eigenvalues = np.sqrt(eigenvalues)
    theta = np.degrees(np.arctan2(*eigenvectors[:,0][::-1]))
    return Ellipse(xy=(mean[0], mean[1]), width=eigenvalues[0]*scale_factor, height=eigenvalues[1]*scale_factor, angle=theta, edgecolor=color, fc='none')

mean1 = np.array([1, 0])
sigma1 = np.array([[3, 2], [2, 3]])
mean2 = np.array([2, 3])
sigma2 = np.array([[2, 0], [0, 1]])

n_samples = 1000

x1, y1 = np.random.multivariate_normal(mean1, sigma1, n_samples).T
x2, y2 = np.random.multivariate_normal(mean2, sigma2, n_samples).T

# Exercise 1
fig = plt.figure(1)
ax = fig.add_subplot(111, aspect='equal')
ax.add_artist(plot_ellipse(mean1, sigma1, 'g', 4))
plt.scatter(x1, y1, c='g', marker='.')
ax.add_artist(plot_ellipse(mean2, sigma2, 'b', 4))
plt.scatter(x2, y2, c='b', marker='.')
ax.add_artist(plot_ellipse(mean1 + mean2, sigma1 + sigma2, 'm', 4))
# For the scatterplot of the sum, uncomment this line
# plt.scatter(x1+x2, y1+y2, c = 'm', marker = '.')
ax.set_xlim(-6, 10)
ax.set_ylim(-6, 10)
plt.title("Distribution of sum (magenta) of two random variables (green and blue)")
plt.show()

# Exercise 2
# # inverted_sigma1 = np.linalg.inv(sigma1)
# # inverted_sigma2 = np.linalg.inv(sigma2)
# # weighted_mean = np.matmul(np.linalg.inv(inverted_sigma1 + inverted_sigma2), (np.matmul(inverted_sigma2, mean1) + np.matmul(inverted_sigma1, mean2)))
# # weighted_sigma = np.linalg.inv(inverted_sigma1 + inverted_sigma2)
# # fig = plt.figure(2)
# # ax = fig.add_subplot(111, aspect='equal')
# # ax.add_artist(plot_ellipse(mean1, sigma1, 'g', 4))
# # plt.scatter(x1, y1, c='g', marker='.')
# # ax.add_artist(plot_ellipse(mean2, sigma2, 'b', 4))
# # plt.scatter(x2, y2, c='b', marker='.')
# # ax.add_artist(plot_ellipse(weighted_mean, weighted_sigma, 'm', 8))
# # plt.title('Product of gaussians')
# # plt.show()

# Exercise 3
# # A = [[-1, 2], [2, 1.5]]
# # b = [3, 0]
# # x5 = []
# # y5 = []
# # for i in range(len(x1)):
# #     x5_element, y5_element = np.matmul(A, [x1[i], y1[i]]) + b
# #     x5.append(x5_element)
# #     y5.append(y5_element)
# # x5 = np.array(x5)
# # y5 = np.array(y5)
# # transformed_mean = np.matmul(A, mean1) + b
# # transformed_sigma = np.matmul(np.matmul(A, sigma1), np.linalg.inv(A))
# # fig = plt.figure(0)
# # ax = fig.add_subplot(111, aspect='equal')
# # ax.add_artist(plot_ellipse(transformed_mean, transformed_sigma, 'm', 10))
# # plt.scatter(x5, y5, c='m', marker='.')
# # plt.scatter(x1, y1, c='g', marker='.')
# # ax.add_artist(plot_ellipse(mean1, sigma1, 'g', 4))
# # plt.title("Linear transformation of normal distributions")
# # plt.show()