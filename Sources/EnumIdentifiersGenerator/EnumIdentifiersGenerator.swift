//
//  EnumIdentifiersGenerator.swift
//
//
//  Created by Simon Sestak on 31/07/2024.
//

import Foundation

@attached(member, names: arbitrary)
public macro EnumIdentifiersGenerator() = #externalMacro(
    module: "EnumIdentifiersGeneratorMacro",
    type: "EnumIdentifiersGeneratorMacro"
)
