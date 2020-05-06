#!/usr/bin/env groovy

library("govuk")

REPOSITORY = 'govuk_schemas'

node {

  try {
    stage('Checkout') {
      checkout scm
    }

    stage('Clean') {
      govuk.cleanupGit()
      govuk.mergeMasterBranch()
    }

    stage("Set up content schema dependency") {
      govuk.contentSchemaDependency()
    }

    stage('Bundle') {
      echo 'Bundling'
      sh("bundle install --path ${JENKINS_HOME}/bundles/${JOB_NAME}")
    }

    stage('Linter') {
      govuk.lintRuby()
    }

    stage('Tests') {
      govuk.setEnvar('RAILS_ENV', 'test')
      govuk.runTests('spec')
    }

    if(env.BRANCH_NAME == "master") {
      stage('Publish Gem') {
        govuk.publishGem(REPOSITORY, env.BRANCH_NAME)
      }
    }

  } catch (e) {
    currentBuild.result = 'FAILED'
    step([$class: 'Mailer',
          notifyEveryUnstableBuild: true,
          recipients: 'govuk-ci-notifications@digital.cabinet-office.gov.uk',
          sendToIndividuals: true])
    throw e
  }
}
