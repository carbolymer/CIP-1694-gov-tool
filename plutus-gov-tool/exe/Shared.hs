{-# LANGUAGE TemplateHaskell                    #-}
{-# LANGUAGE DataKinds                          #-}
{-# LANGUAGE NoImplicitPrelude                  #-}

module Shared where

import PlutusTx.Prelude
    ( ($),
      Bool(..),
      check,
      BuiltinUnit)
import PlutusTx.Builtins
    ( error, BuiltinData)
import PlutusLedgerApi.V3
    ( ScriptContext(..),
      UnsafeFromData (..))
import PlutusTx
    ( compile,
      CompiledCode,
      makeIsDataIndexed )

-- Helper function to wrap a script to error on the return of a False.
{-# INLINABLE wrapOneArg #-}
wrapOneArg  :: (ScriptContext -> Bool)
            -> (BuiltinData -> BuiltinUnit)
wrapOneArg f ctx =
  check $ f
      (unsafeFromBuiltinData ctx)

{-# INLINABLE wrapTwoArgs #-}
wrapTwoArgs  :: (UnsafeFromData a)
                => (a -> ScriptContext -> Bool)
                -> (BuiltinData -> BuiltinData -> BuiltinUnit)
wrapTwoArgs f a ctx =
  check $ f
      (unsafeFromBuiltinData a)
      (unsafeFromBuiltinData ctx)

{-# INLINABLE wrapThreeArgs #-}
wrapThreeArgs :: ( UnsafeFromData a
             , UnsafeFromData b)
             => (a -> b -> ScriptContext -> Bool)
             -> (BuiltinData -> BuiltinData -> BuiltinData -> BuiltinUnit)
wrapThreeArgs f a b ctx =
  check $ f
      (unsafeFromBuiltinData a)
      (unsafeFromBuiltinData b)
      (unsafeFromBuiltinData ctx)

{-# INLINABLE wrapFourArgs #-}
wrapFourArgs  :: (UnsafeFromData a
                , UnsafeFromData b
                , UnsafeFromData c)
                => (a -> b -> c -> ScriptContext -> Bool)
                -> (BuiltinData -> BuiltinData -> BuiltinData -> BuiltinData -> BuiltinUnit)
wrapFourArgs f a b c ctx =
  check $ f
      (unsafeFromBuiltinData a)
      (unsafeFromBuiltinData b)
      (unsafeFromBuiltinData c)
      (unsafeFromBuiltinData ctx)
