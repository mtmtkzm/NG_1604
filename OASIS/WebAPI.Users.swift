//
//  WebAPI.Users.swift
//  OASIS
//
//  Created by 後藤誉昌 on 2016/11/05.
//  Copyright © 2016年 othlotech. All rights reserved.
//

import SwiftTask
import Alamofire
import Himotoki

extension WebAPI {

    struct Users {

        typealias VoidTask = Task<Void, Void, Error>
        typealias UserTask = Task<Void, (User, Recommends), Error>

        static func create(user: RegisteringUser) -> VoidTask {
            return VoidTask { _, fulfill, reject, _ in
                guard let uuid = WebAPI.uuid else {
                    reject(AppError.unauthorized)
                    return
                }

                let url = AppConfig.WebAPI.BaseURL + "/users"

                let params: Parameters = [
                    "uuid": uuid,
                    "department": user.department,
                    "gender": user.gender,
                    "name": user.name,
                    "grade": user.grade,
                    "profile": user.profile,
                    "profile_img": user.image,
                    "univ_name": user.univ,
                    "classes": [
                        "mon": user.classes.mon,
                        "tue": user.classes.tue,
                        "wed": user.classes.wed,
                        "thu": user.classes.thu,
                        "fri": user.classes.fri,
                    ]
                ]

                Alamofire.request(url, method: .post, parameters: params)
                    .responseJSON { response in
                        if let error = response.result.error {
                            reject(error)
                        }

                        fulfill(())
                }
            }
        }

        static func show(uuid: String) -> UserTask {
            return UserTask { _, fulfill, reject, _ in
                let url = AppConfig.WebAPI.BaseURL + "/users/" + uuid

                Alamofire.request(url)
                    .responseJSON { response in
                        if let error = response.result.error {
                            reject(error)
                        }

                        do {
                            if let data = response.result.value {
                                let user = try User.decodeValue(data, rootKeyPath: "user")
                                let recommends = try Recommends.decodeValue(data)
                                fulfill(user, recommends)
                            }
                        } catch {
                            reject(error)
                        }

                        reject(AppError.unknown)
                }
            }
        }

        static func me() -> UserTask {
            guard let uuid = WebAPI.uuid else {
                return UserTask(error: AppError.unauthorized)
            }
            return show(uuid: uuid)
        }

        static func remove() -> VoidTask {
            return VoidTask { _, fulfill, reject, _ in
                guard let uuid = WebAPI.uuid else {
                    reject(AppError.unauthorized)
                    return
                }

                let url = AppConfig.WebAPI.BaseURL + "/users/" + uuid + "/remove"

                Alamofire.request(url, method: .post)
                    .responseJSON { response in
                        if let error = response.result.error {
                            reject(error)
                        }

                        fulfill(())
                }
            }
        }

        static func like(opponent: String) -> VoidTask {
            return VoidTask { _, fulfill, reject, _ in
                guard let uuid = WebAPI.uuid else {
                    reject(AppError.unauthorized)
                    return
                }

                let url = AppConfig.WebAPI.BaseURL + "/users/" + uuid + "/like"

                let params: Parameters = [
                    "opponent_uuid": opponent,
                    "match_result": true
                ]

                Alamofire.request(url, method: .post, parameters: params)
                    .responseJSON { response in
                        if let error = response.result.error {
                            reject(error)
                        }

                        fulfill(())
                }
            }
        }

        static func dislike(opponent: String) -> VoidTask {
            return VoidTask { _, fulfill, reject, _ in
                guard let uuid = WebAPI.uuid else {
                    reject(AppError.unauthorized)
                    return
                }

                let url = AppConfig.WebAPI.BaseURL + "/users/" + uuid + "/like"

                let params: Parameters = [
                    "opponent_uuid": opponent,
                    "match_result": false
                ]

                Alamofire.request(url, method: .post, parameters: params)
                    .responseJSON { response in
                        if let error = response.result.error {
                            reject(error)
                        }

                        fulfill(())
                }
            }
        }
    }
}
