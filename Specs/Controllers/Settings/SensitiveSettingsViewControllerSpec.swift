//
//  SensitiveSettingsViewControllerSpec.swift
//  Ello
//
//  Created by Tony DiPasquale on 3/24/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble


class SensitiveSettingsViewControllerSpec: QuickSpec {
    override func spec() {
        var subject = SensitiveSettingsViewController.instantiateFromStoryboard()

        beforeSuite {
            ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
        }

        afterSuite {
            ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
        }

        beforeEach {
            subject = SensitiveSettingsViewController.instantiateFromStoryboard()
            subject.loadView()
        }

        describe("initialization") {
            describe("storyboard") {
                beforeEach {
                    subject.viewDidLoad()
                }

                it("IBOutlets are not nil") {
                    expect(subject.usernameView).notTo(beNil())
                    expect(subject.emailView).notTo(beNil())
                    expect(subject.passwordView).notTo(beNil())
                    expect(subject.currentPasswordField).notTo(beNil())
                }
            }
        }

        describe("viewDidLoad") {
            it("sets the text fields from the current user") {
                let user: User = stub(["username": "TestName", "email": "some@guy.com"])
                subject.currentUser = user
                subject.viewDidLoad()

                expect(subject.usernameView.textField.text) == "TestName"
                expect(subject.emailView.textField.text) == "some@guy.com"
                expect(subject.passwordView.textField.text) == ""
            }
        }

        describe("isUpdatable") {
            beforeEach {
                let user: User = stub(["username": "TestName", "email": "some@guy.com"])
                subject.currentUser = user
                subject.viewDidLoad()
            }

            context("username") {
                context("is changed") {
                    it("isUpdatable is true") {
                        expect(subject.isUpdatable).to(beFalse())
                        subject.usernameView.textField.text = "something"
                        expect(subject.isUpdatable).to(beTrue())
                    }
                }
                
                context("is reset") {
                    it("isUpdatable is false") {
                        subject.usernameView.textField.text = "something"
                        expect(subject.isUpdatable).to(beTrue())
                        subject.usernameView.textField.text = "TestName"
                        expect(subject.isUpdatable).to(beFalse())
                    }
                }
            }

            context("email") {
                context("is changed") {
                    it("isUpdatable is true") {
                        expect(subject.isUpdatable).to(beFalse())
                        subject.emailView.textField.text = "no-one@email.com"
                        expect(subject.isUpdatable).to(beTrue())
                    }
                }
                
                context("is reset") {
                    it("isUpdatable is false") {
                        subject.emailView.textField.text = "no-one@email.com"
                        expect(subject.isUpdatable).to(beTrue())
                        subject.emailView.textField.text = "some@guy.com"
                        expect(subject.isUpdatable).to(beFalse())
                    }
                }
            }

            context("password") {
                context("is set") {
                    it("isUpdatable is true") {
                        expect(subject.isUpdatable).to(beFalse())
                        subject.passwordView.textField.text = "anything"
                        expect(subject.isUpdatable).to(beTrue())
                    }
                }
                
                context("is empty") {
                    it("isUpdatable is false") {
                        subject.passwordView.textField.text = "anything"
                        expect(subject.isUpdatable).to(beTrue())
                        subject.passwordView.textField.text = ""
                        expect(subject.isUpdatable).to(beFalse())
                    }
                }
            }
        }

        describe("valueChanged") {
            beforeEach {
                subject.viewDidLoad()
            }

            it("calls the delegate function when set") {
                let fake = FakeSensitiveSettingsDelegate()
                subject.delegate = fake
                subject.valueChanged()
                expect(fake.didCall).to(beTrue())
            }
        }

        describe("height") {
            beforeEach {
                let user: User = stub(["username": "TestName", "email": "some@guy.com"])
                subject.currentUser = user
                subject.viewDidLoad()
            }

            context("isUpdatable is true") {
                it("returns 89 * 3 + 128") {
                    subject.passwordView.textField.text = "anything"
                    expect(subject.isUpdatable).to(beTrue())
                    expect(subject.height) == 89 * 3 + 128
                }
            }

            context("isUpdatable is false") {
                it("returns 89 * 3") {
                    expect(subject.isUpdatable).to(beFalse())
                    expect(subject.height) == 89 * 3
                }
            }
        }
    }
}

class FakeSensitiveSettingsDelegate: SensitiveSettingsDelegate {
    var didCall = false

    func sensitiveSettingsDidUpdate() {
        didCall = true
    }
}
