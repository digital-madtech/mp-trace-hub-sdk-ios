//
//  Strongify.swift
//

//func strongify<Context: AnyObject, Arguments>(_ context: Context?,
//                                              closure: @escaping (Context, Arguments) -> Void) -> (Arguments) -> Void {
//    return { [weak context] arguments in
//        guard let strongContext = context else { return }
//        closure(strongContext, arguments)
//    }
//}
//
//func strongify<Context: AnyObject>(_ context: Context?, closure: @escaping (Context) -> Void) {
//    guard let strongContext = context else { return }
//    closure(strongContext)
//}
